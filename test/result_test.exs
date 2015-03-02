defmodule Result.Test do
  use ExUnit.Case, async: true
  use Monad.Operators
  import Curry
  import Monad.Result

  doctest Monad.Result

  test "left identity law" do
    constructor = &(success &1)
    fun = &(success(&1 * 2))
    assert Monad.Law.left_identity?(42, constructor, fun)
  end

  test "right identity law" do
    constructor = &(success &1)
    assert Monad.Law.right_identity?(success(42), constructor)
  end

  test "associativity law" do
    fun1 = &(success(&1 * 2))
    fun2 = &(success(&1 + 3))
    assert Monad.Law.associativity?(success(42), fun1, fun2)
  end

  test "bind" do
    assert success(42) ~>> &(success &1) |> unwrap! == 42
    assert success(42) ~>> &(success &1 * 2) |> unwrap! == 84
    assert success(42) ~>> &(success &1 * &1) |> unwrap! == 1764
  end

  test "fmap one" do
    assert (&(&1)) <|> success(42) |> unwrap! == 42
  end

  test "fmap two" do
    assert curry(&(&1 + &2)) <|> success(42) <~> success(100) |> unwrap! == 142
  end

  test "fmap three" do
    assert curry(&(&1 + &2 + &3))
    <|> success(42)
    <~> success(100)
    <~> success(1000)
    |> unwrap! == 1142
  end

  test "fmap fail first" do
    assert curry(&(&1 + &2 + &3))
           <|> error("oops")
           <~> success(100)
           <~> success(1000)
           |> error?
  end

  test "fmap fail second" do
    assert curry(&(&1 + &2 + &3))
           <|> success(42)
           <~> error("oops")
           <~> success(1000)
           |> error?
  end

  test "fmap fail last" do
    assert curry(&(&1 + &2 + &3))
           <|> success(42)
           <~> success(100)
           <~> error("oops")
           |> error?
  end

  test "apply success" do
    assert success(&(&1 * 2)) <~> success(42) |> unwrap! == 84
  end

  test "apply error" do
    assert success(&(&1 * 2)) <~> error("oops") |> error?
  end

  test "apply error fun" do
    assert error("oops") <~> success(42) |> error?
  end
end