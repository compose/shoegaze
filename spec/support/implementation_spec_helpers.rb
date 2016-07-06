module ImplementationSpecHelpers
  # yeah, this is a bit of a monster
  def expect_default_scenario_to_be_defined_for_scope(scope)
    expect(Shoegaze::Scenario::Orchestrator).to receive(:new).
                                                  with(mock_class, mock_double, scope, method_name).
                                                  and_return(fake_scenario_orchestrator)

    expect(mock_double).to receive(:add_default_scenario).with(method_name, anything) do |name, block|
      expect(name).to eq(method_name)
      expect(fake_scenario_orchestrator).to receive(:with).with(*fake_method_args).and_return(fake_scenario_orchestrator)
      expect(fake_scenario_orchestrator).to receive(:execute_scenario).with(*fake_scenario)

      block.call(*fake_method_args)
    end

    implementation.default(&fake_block)
  end
end
