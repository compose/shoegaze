# Shoegaze

Create mocks of modules (especially clients) with easily-defined scenarios (success, invalid, etc) and an optional in-memory persistence layer.

## The problem

When unit testing, libraries that constitute dependencies become cumbersome to stub as complexity increases. Most of the time you want to simulate various high-level scenarios that can be produced in your library. Stubbing those high-level scenarios in your tests with low-level tools can be cumbersome and requires a lot of logic about your dependencies to be sprinked throughout your tests. Outright mocking the libraries in various ways (Webmock, VCR, DIY fake classes) can be tricky.

## How Shoegaze solves the problem

When you mock a library using Shoegaze, Shoegaze creates an Rspec double of the library. Using a simple DSL you can specify test `implementations` and their `scenarios` for the mocked library's methods. Swap out your real library implementation for the mock, then drive the high-level behavior in your tests by specifying the scenarios to run. This provides a consistent interface for creating mocks and forces you to mock your library's API, which is the right place to separate the concerns of the library from your tests.

## Mock Twitter Client Example

``` ruby
class FakeTwitterClient < Shoegaze::Mock
  # optional. provides in-memory persisted ActiveModel objects so that
  # your mock can 'remember' its state
  extend Shoegaze::Datastore

  mock Twitter::Client

  # creates both a FakeTwitterClient::Update 'model' and a FactoryGirl
  # factory for the model
  datastore :Update do
    id{ BSON::ObjectId.new }
    date{ Time.new }
    body{ Faker::Lorem.sentence }
    location{ [Faker::Address.latitude, Faker::Address.longitude] }
  end

  implement :update do
    scenario :success do
      # optional. you can provide transforms for your 'models' to
      # represent the data returned by the implementation in various
      # ways
      representer do
        include Representable::JSON

        property :id
        property :date
        property :body

        # notice we omit location in this representation
      end

      # this method will call :as_json on the representer, meaning it
      # will return a hash. you can also call to_json, for example, to
      # return stringified JSON instead
      represent_method :as_json

      datasource do
        # generate an update and store it in the memory store (you can
        # grab it with FakerTwitterClient::Update.find(update.id)
        FactoryGirl.create(Update)
      end
    end

    scenario :unavailable do
      datasource do |id|
        raise Twitter::ConnectionFailed.new(Struct.new(:status).new(status: "504"))
      end
    end
  end
end

```

``` ruby
class ProductMaker
  class << self
    def create(name)
      # ...
      twitter_client.update("We have a new product: #{product.name}!")

      product
    end

    private

    def twitter_client
      @twitter_client ||= Twitter::Client.new
    end
  end
end
```

``` ruby
RSpec.configure do |config|
  config.before :each do
    # swap out the twitter client for the mock in all tests
    stub_const("Twitter::Client", FakeTwitterClient.proxy)
  end
end

```

```ruby
describe ProductMaker do
  describe "#create" do
    describe "tweeting" do
      describe "is successful" do
        before :each do
          FakeTwitterClient.calling(:update).with(update.body).yields(:success)
        end

        it "posts a twitter update" do
          product = ProductMaker.create("some_product")

          update = FakeTwitterClient::Update.find_by_body("We have a new product: #{product.name}!")
          expect(update).to exist
        end
      end

      describe "is unavailable" do
        before :each do
          FakeTwitterClient.calling(:update).with(update.body).yields(:unavailable)
        end

        it "raises a Twitter connection failed error" do
          expect{ ProductMaker.create("some_product") }.to raise_exception(Twitter::ConnectionFailed)
        end
      end
    end
  end
end
```

# Unit Test Manifesto

## Inject mock dependencies

If a component calls a Twitter client library, create a mock of the
Twitter client library's API and swap the real implementation for
the mock.

## Steer injected dependencies at the highest practical level (success, failure, etc)

If you want to test how the component handles Twitter being
unavailable, create a scenario in the mock implementation of the
Twitter client library that simulates how the real implementation
behaves when Twitter is unavailable.

## Test the wiring & the I/O, not the code

Prove that your dependencies were called with the input you
expect. In a unit test that should be good enough most of the time.
If those dependency calls would have produced side-effects and it
matters to your code, your unit may be too complex. Consider
refactoring. If the side-effects the core intent of the the
implementation, simulate the side-effects rather than actually
producing the side-effects.

## Use the dumbest possible test subjects that can prove the I/O works

Much of the time arguments to the API you're testing are not
inspected in any meaningful way. If all you need to do is prove the
argument was passed-along correctly, a `double` can do the job
rather than the real argument type.

## Generate test data randomly and dynamically rather than use fixtures

Use Faker. Generate test data in the most flexible format. Generally
that's a ruby object with accessors produced by Factory Girl, since
it can easily be turned into a hash, JSON, or left as-is.

## Test the immediate layer of the component you're testing

If a component calls Net:HTTP, don't serve HTTP, create a mock
Net:HTTP object and prove it was called with the anticipated I/O.
