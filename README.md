# Intro
Walkthrough of sample blue/green deploy process using consul service tags and KVP tag selector


## Setup

Ensure you have consul agent and consul-template installed.  I'm testing with consul v0.6.3 and consul-template v0.12.0.  All provided, commands assume they're on the PATH.

Clone this repo:

```
git clone https://github.com/j-oconnor/consul-spinnaker-example.git
cd consul-example
```

Start consul in server mode advertising localhost

`consul agent -server -dev -advertise 127.0.0.1`

## Demo
```
./demo.sh
```
