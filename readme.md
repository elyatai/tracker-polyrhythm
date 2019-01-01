# tracker polyrhythms

generates polyrhythms in tracker notations

## usage notes

- defaults to 4 lines between pulses. to change this, use the `--multiplier` flag
- the faster of the two rhythms will be used for the "on the beat" pulses; this cannot be changed (yet)
- outputs tick commands without any instruction prefix. use `-R` or `-O` to use Renoise's / OpenMPT's notation, or use `--prefix` to set your own
- Renoise doesn't seem to accept clipboard xml from outside the program, but OpenMPT works fine (`-c`)

## dependencies

docopt

## credits

main logic + idea from [lynn on twitter](https://twitter.com/chordbug/status/1063733473586884609)
