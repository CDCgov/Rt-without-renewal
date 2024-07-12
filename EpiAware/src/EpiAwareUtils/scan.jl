"""
Apply `f` to each element of `xs` and accumulate the results.

`f` must be a [callable](https://docs.julialang.org/en/v1/manual/methods/#Function-like-objects)
    on a sub-type of `AbstractModel`.

### Design note
`scan` is being restricted to `AbstractModel` sub-types to ensure:
    1. That compiler specialization is [activated](https://docs.julialang.org/en/v1/manual/performance-tips/#Be-aware-of-when-Julia-avoids-specializing)
    2. Also avoids potential compiler [overhead](https://docs.julialang.org/en/v1/devdocs/functions/#compiler-efficiency-issues)
    from specialisation on `f<: Function`.



# Arguments
- `f`: A callable/functor that takes two arguments, `carry` and `x`, and returns a new
    `carry` and a result `y`.
- `init`: The initial value for the `carry` variable.
- `xs`: An iterable collection of elements.

# Returns
- `ys`: An array containing the results of applying `f` to each element of `xs`.
- `carry`: The final value of the `carry` variable after processing all elements of `xs`.

# Examples

```jldoctest
using EpiAware

struct Adder end <: EpiAwareBase.AbstractModel
function (a::Adder)(carry, x)
    carry + x, carry + x
end

scan(Adder(), 0, 1:5)
#output
([1, 3, 6, 10, 15], 15)
"""
function scan(f::F, init, xs) where {F <: EpiAwareBase.AbstractModel}
    carry = init
    ys = similar(xs)
    for (i, x) in enumerate(xs)
        carry, y = f(carry, x)
        ys[i] = y
    end
    return ys, carry
end
