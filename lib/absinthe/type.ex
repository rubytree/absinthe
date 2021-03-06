defmodule Absinthe.Type do

  @moduledoc false

  alias __MODULE__

  # ALL TYPES

  @type_modules [Type.Scalar, Type.ObjectType, Type.InterfaceType, Type.Union, Type.Enum, Type.InputObjectType, Type.List, Type.NonNull]

  @typedoc "These are all of the possible kinds of types."
  @type t :: Type.Scalar.t | Type.ObjectType.t | Type.FieldDefinition.t | Type.InterfaceType.t | Type.Union.t | Type.Enum.t | Type.InputObjectType.t | Type.List.t | Type.NonNull.t

  @typedoc "A type identifier"
  @type identifier_t :: atom

  @doc "Determine if a struct matches one of the types"
  @spec type?(any) :: boolean
  def type?(%{__struct__: mod}) when mod in @type_modules, do: true
  def type?(_), do: false

  # INPUT TYPES

  @input_type_modules [Type.Scalar, Type.Enum, Type.InputObjectType, Type.List, Type.NonNull]

  @typedoc "These types may be used as input types for arguments and directives."
  @type input_t :: Type.Scalar.t | Type.Enum.t | Type.InputObjectType.t | Type.List.t | Type.NonNull.t

  @doc "Determine if a term is an input type"
  @spec input_type?(any) :: boolean
  def input_type?(term) do
    term
    |> named_type
    |> do_input_type?
  end

  defp do_input_type?(%{__struct__: mod}) when mod in @input_type_modules, do: true
  defp do_input_type?(_), do: false

  # OBJECT TYPE

  @doc "Determine if a term is an object type"
  @spec object_type?(any) :: boolean
  def object_type?(%Type.ObjectType{}), do: true
  def object_type?(_), do: false

  @doc "Resolve a type for a value from an interface (if necessary)"
  @spec resolve_type(t, any) :: t
  def resolve_type(%{resolve_type: resolver}, value), do: resolver.(value)
  def resolve_type(type, _value), do: type

  # TYPE WITH FIELDS

  @doc "Determine if a type has fields"
  @spec fielded?(any) :: boolean
  def fielded?(%{fields: _}), do: true
  def fielded?(_), do: false

  # OUTPUT TYPES

  @output_type_modules [Type.Scalar, Type.ObjectType, Type.InterfaceType, Type.Union, Type.Enum]

  @typedoc "These types may be used as output types as the result of fields."
  @type output_t :: Type.Scalar.t | Type.ObjectType.t | Type.InterfaceType.t | Type.Union.t | Type.Enum.t

  @doc "Determine if a term is an output type"
  @spec output_type?(any) :: boolean
  def output_type?(term) do
    term
    |> named_type
    |> do_output_type?
  end

  defp do_output_type?(%{__struct__: mod}) when mod in @output_type_modules, do: true
  defp do_output_type?(_), do: false

  # LEAF TYPES

  @leaf_type_modules [Type.Scalar, Type.Enum]

  @typedoc "These types may describe types which may be leaf values."
  @type leaf_t :: Type.Scalar.t | Type.Enum.t

  @doc "Determine if a term is a leaf type"
  @spec leaf_type?(any) :: boolean
  def leaf_type?(term) do
    term
    |> named_type
    |> do_leaf_type?
  end

  defp do_leaf_type?(%{__struct__: mod}) when mod in @leaf_type_modules, do: true
  defp do_leaf_type?(_), do: false

  # COMPOSITE TYPES

  @composite_type_modules [Type.ObjectType, Type.InterfaceType, Type.Union]

  @typedoc "These types may describe the parent context of a selection set."
  @type composite_t :: Type.ObjectType.t | Type.InterfaceType.t | Type.Union.t

  @doc "Determine if a term is a composite type"
  @spec composite_type?(any) :: boolean
  def composite_type?(%{__struct__: mod}) when mod in @composite_type_modules, do: true
  def composite_type?(_), do: false

  # ABSTRACT TYPES

  @abstract_type_modules [Type.InterfaceType, Type.Union]

  @typedoc "These types may describe the parent context of a selection set."
  @type abstract_t :: Type.InterfaceType.t | Type.Union.t

  @doc "Determine if a term is an abstract type"
  @spec abstract?(any) :: boolean
  def abstract?(%{__struct__: mod}) when mod in @abstract_type_modules, do: true
  def abstract?(_), do: false

  # NULLABLE TYPES

  @nullable_type_modules [Type.Scalar, Type.ObjectType, Type.InterfaceType, Type.Union, Type.Enum, Type.InputObjectType, Type.List]

  @typedoc "These types can all accept null as a value."
  @type nullable_t :: Type.Scalar.t | Type.ObjectType.t | Type.InterfaceType.t | Type.Union.t | Type.Enum.t | Type.InputObjectType.t | Type.List.t

  @doc "Unwrap the underlying nullable type or return unmodified"
  @spec nullable(any) :: nullable_t | t # nullable_t is a subset of t, but broken out for clarity
  def nullable(%Type.NonNull{of_type: nullable}), do: nullable
  def nullable(term), do: term

  @doc "Determine if a type is non null"
  @spec non_null?(t) :: boolean
  def non_null?(%Type.NonNull{}), do: true
  def non_null?(_), do: false

  # NAMED TYPES

  @named_type_modules [Type.Scalar, Type.ObjectType, Type.InterfaceType, Type.Union, Type.Enum, Type.InputObjectType]

  @typedoc "These named types do not include modifiers like Absinthe.Type.List or Absinthe.Type.NonNull."
  @type named_t :: Type.Scalar.t | Type.ObjectType.t | Type.InterfaceType.t | Type.Union.t | Type.Enum.t | Type.InputObjectType.t

  @doc "Determine the underlying named type, if any"
  @spec named_type(any) :: nil | named_t
  def named_type(%{__struct__: mod, of_type: unmodified}) when mod in [Type.List, Type.NonNull] do
    named_type(unmodified)
  end
  def named_type(%{__struct__: mod} = term) when mod in @named_type_modules, do: term
  def named_type(_), do: nil


  @doc "Determine if a type is named"
  @spec named?(t) :: boolean
  def named?(%{name: _}), do: true
  def named?(_), do: false

  # WRAPPERS

  @wrapping_modules [Type.List, Type.NonNull]

  @typedoc "A type wrapped in a List on NonNull"
  @type wrapping_t :: Type.List.t | Type.NonNull.t

  @spec wrapped?(t) :: boolean
  def wrapped?(%{__struct__: mod}) when mod in @wrapping_modules, do: true
  def wrapped?(_), do: false

  @doc "Unwrap a type from a List or NonNull"
  @spec unwrap(wrapping_t | t) :: t
  def unwrap(%{of_type: t}), do: t
  def unwrap(type), do: type

  # VALID TYPE

  def valid_input?(%Type.NonNull{}, nil) do
    false
  end
  def valid_input?(%Type.NonNull{of_type: internal_type}, value) do
    valid_input?(internal_type, value)
  end
  def valid_input?(_type, nil) do
    true
  end
  def valid_input?(%{parse: parse}, value) do
    case parse.(value) do
      {:ok, _} -> true
      :error -> false
    end
  end
  def valid_input?(_) do
    true
  end

  # TODO: Support __typename, __schema, and __type for introspection
  def field(type, name) do
    type.fields
    |> Map.get(name |> String.to_atom)
  end

end
