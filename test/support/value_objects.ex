defmodule Fixtures do
  defmodule Decimal do
    use CivilCode.ValueObject, type: :decimal
  end

  defmodule Date do
    use CivilCode.ValueObject, type: :date
  end

  defmodule Integer do
    use CivilCode.ValueObject, type: :integer
  end

  defmodule NaiveMoney do
    use CivilCode.ValueObject, type: :naive_money
  end

  defmodule NonNegInteger do
    use CivilCode.ValueObject, type: :non_neg_integer
  end

  defmodule String do
    use CivilCode.ValueObject, type: :string
  end

  defmodule Uuid do
    use CivilCode.ValueObject, type: :uuid
  end
end
