import options

type
    Inputs*[I] = ref object
        list*  : seq[I]
        index* : int
        final* : I

    Rule[I, R] = proc (inputs: Inputs[I]): Option[R]

    StreamOutOfBounds* = object of ValueError

# utility functions

converter toBool*[I](a: Option[I]): bool = a.isSome()

# template `:=`*[T](a: untyped, b: T): T =
#     let a = b
#     a


template `:=`*(a, b): bool =
    let a = b
    a


# stream functions

proc peek*[I](inputs: Inputs[I]): I =
    if inputs.index < inputs.list.len :
        return inputs.list[inputs.index]

    if inputs.index == inputs.list.len :
        return inputs.final
    
    raise newException(StreamOutOfBounds, "failed to recognize the end of steam")

proc skip*[I](inputs: Inputs[I]) =
    inputs.index += 1

proc read*[I](inputs: Inputs[I]): I =
    # get the current token
    let input = inputs.peek()

    # increment are location in the list
    inputs.skip()

    # return the current token
    return input

proc save*[I](inputs: Inputs[I]): int =
    return inputs.index

proc load*[I](inputs: Inputs[I], index: int) =
    inputs.index = index

proc next*[I](inputs: Inputs[I], expected: I): Option[I] =
    let input = inputs.peek()

    if input == expected :
        inputs.next()

        return some(input)

    return none(I)

proc next*[I, R](inputs: Inputs[I], rule: Rule[I, R]): Option[R] =
    let save = inputs.save()

    let node = rule(inputs)

    if not node :
        inputs.load(save)

    return node

# more advanced reading methods

proc loop*[I, R](inputs: Inputs[I], rule: Rule[I, R]): Option[seq[R]] =
    var values = newSeq[R]()

    while value := inputs.next(rule):
        values.add( value.get )

    return some(values)

proc mult*[I, R](inputs: Inputs[I], rule: Rule[I, R]): Option[seq[R]] =
    if value := inputs.next(rule) :
        var values = @[ value.get ]

        while value := inputs.next(rule):
            values.add( value.get )

        return some(values)

    return none(seq[R])