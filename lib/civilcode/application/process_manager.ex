defmodule CivilCode.ProcessManager do
  @moduledoc """
  A Process Manager integrates with multiple bounded contexts to perform a larger task.

  ## Usage

  Currently ProcessManagers are not used in our applications.

  ## From the Experts

  > Sometimes business processes span multiple bounded contexts. For these cases, you employ the
  > use of a process manager to coordinate business tasks. Figure 8-15 shows a process manager that
  > contains business task logic to coordinate larger processes. Similar to the application services,
  > the process managers will be stateless apart from the state used to track task progression,
  > and will delegate back to applications to carry out any work. - [PPPoD p. 118]

  > Consider a Process Manager as a sort of Application Service on top of the other components.
  It can contain one or more stateful aggregates that keep the state of a long running process
  depending on requirements.

  -- [Domain Driven Design, Event Sourcing and Micro-Services explained for developers](http://www.dinuzzo.co.uk/2017/04/28/domain-driven-design-event-sourcing-and-micro-services-explained-for-developers/)
  """

  defmacro __using__(_) do
  end
end
