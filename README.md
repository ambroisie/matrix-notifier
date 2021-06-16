# matrix-notifier

This is a simple to send a message to a Matrix room. It automatically logs in
and sends the message when invoked. This was written to be used a notification
script in my CI/CD pipelines.

## How to use

You need to define the following environment variables for the script to be 
executed correctly:

* `USER`: the user to login as.
* `PASS`: the password to login with.
* `ADDRESS`: the address of the homeserver to connect to.
* `ROOM`: the room id, as can be found in the room parameters.
* `MESSAGE`: the message you wish to send to the room.

### Example

```sh
export ADDRESS='https://matrix.org'
export USER='username'
export PASS='password'
export ROOM='!aaaaaaaaaaaaaaaaaa:matrix.org'
export MESSAGE='This is my test message'
./matrix-notifier
```

## How to run/install

This script is packaged with `Nix`, you can just use `nix run .` to run it.

The only dependencies are `bash`, `curl`, and `jq`, install those and you should
be ready to go! Format is needed when using formatting (enabled by default).
