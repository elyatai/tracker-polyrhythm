# tracker polyrhythms

generates polyrhythms in tracker notations

## example usage

```
$ ruby main.rb 3 4
row  0: 0
row  5: 4
row 10: 8

$ ruby main.rb -R --ticks=16 8 9
row  0: Q00
row  4: Q08
row  9: Q00
row 13: Q08
row 18: Q00
row 22: Q08
row 27: Q00
row 31: Q08

$ ruby main.rb -cO 50 60
ModPlug Tracker MPT
|        SD0
|        ...
|        ...
|        ...
|        SD9
|        ...
|        ...
|        ...
|        ...
|        SD7
|        ...
|        ...
|        ...
|        ...
|        SD4
|        ...
|        ...
|        ...
|        ...
|        SD2
```

## usage notes

- defaults to 4 lines between pulses. to change this, use the `--multiplier` flag
- the faster of the two rhythms will be used for the "on the beat" pulses; this cannot be changed (yet)
- outputs tick commands without any instruction prefix. use `-R` or `-O` to use Renoise's / OpenMPT's notation, or use `--prefix` to set your own
- Renoise doesn't seem to accept clipboard xml from outside the program, but OpenMPT works fine (`-c`)

## dependencies

docopt

## credits

main logic + idea from [lynn on twitter](https://twitter.com/chordbug/status/1063733473586884609)
