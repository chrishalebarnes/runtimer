Runtimer
========

Application runtime configuration for applications built in [the D programming language](http://dlang.org/).

## Getting Started
Import `runtimer`
```D
import runtimer;
```
Write a `struct` that maps to a `JSON` object.
```D
struct App
{
    short port;
    string hostname;
}
```
New up the configuration class inside of `main`. You can skip `args` if you don't want to be able to override the configuration from the command line. Finally, call `initialize` to have `runtimer` read in the configuration from disk.
```D
void main(string[] args)
{
	auto configuration = new Configuration!(App)(args);
	configuration.initialize();
}
```
That will read in a configuration file from the root of the project called `configuration.json` that looks like this:
```json
{
  "environment-path": "configuration",
  "default-environment": "development"
}
```
`configuration.json` specifies the default configuration and the path of all of the configurations. The actual configurations can be whatever you want. Here is an example with `port` and `hostname`.
#### configuration/development.json
```json
{
  "port": 3000,
  "hostname": "127.0.0.1"
}
```
#### configuration/test.json
```json
{
  "port": 80,
  "hostname": "192.168.1.300"
}
```

Now you can run the `default-environment` with

    dub

Or you can specify which configuration to use like this:

    dub -- --environment test

An environment can be specified with `--environment` or `-e`.
A path can be specified with `--path` or `-p`

Without `dub` you can pass in configurations as arguments to the compiled binary as well.

## Compiling and Running Tests
Compile `runtimer` with `dub` by simply running

    dub  

Run the tests with `dub` by simply running

    dub test

## License and Copyright

See [LICENSE](https://github.com/chrishalebarnes/runtimer/blob/master/LICENSE)
