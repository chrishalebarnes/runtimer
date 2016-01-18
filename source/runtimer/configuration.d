/**
    Copyright: © 2016 Chris Barnes
    License: The MIT License, see license file
    Authors: Chris Barnes
*/
module runtimer.configuration;

import std.conv;
import std.file;
import std.getopt;
import std.json;
import vibe.data.json;

/**
     Represents application configuration where a struct T maps to some JSON configuration.
 */
class Configuration(T)
{
    /**
        Creates a new configuration object wihout any command line overrides.
        Params:
            path = path to a JSON file containing the default path and configuration filename
    */
    this(string path = "configuration.json")
    {
        this.path = path;
    }

    /**
        Creates a new configuration object given the command line override args array.
        Params:
            path = path to a JSON file containing the default path and configuration filename
    */
    this(string[] args, string path = "configuration.json")
    {
        getopt(args,
            "e|environment",  &environmentArgument,
            "p|path",  &pathArgument
        );
        this(path);
    }

    /**
        Reads in the current configuration into this.application
     */
    void initialize()
    {
        JSONValue[string] configuration;
        if(this.pathArgument == "")
        {
            configuration = parseJSON(to!string(read(this.path))).object;
        }
        string defaultEnvironment = this.environmentArgument != "" ? this.environmentArgument : configuration["default-environment"].str;
        string environmentPath = this.pathArgument != "" ? this.pathArgument : configuration["environment-path"].str;
        this.application = deserializeJson!T(to!(string)(read(environmentPath ~ "/" ~ defaultEnvironment ~ ".json")));
    }

    T application;

    private:
        string path;
        string environmentArgument;
        string pathArgument;
}

version(unittest)
{
    struct Host
    {
      string name;
      ushort port;
    }

    struct Credentials
    {
      string username;
      string password;
    }

    struct Http
    {
        Host host;
    }

    struct Data
    {
        Host host;
        Credentials credentials;
        string database;
    }

    struct Assets
    {
        string directory;
        string files;
    }

    struct Logging
    {
        string level;
        string path;
    }

    struct App
    {
        string name;
        Http http;
        Data data;
        Assets assets;
        Logging logging;
    }
}

unittest
{
    auto configuration = new Configuration!(App)("fixtures/configuration.json");
    configuration.initialize();
    assert(configuration.application.name == "some-name");
    assert(configuration.application.http.host.port == to!short(3000));
    assert(configuration.application.http.host.name == "127.0.0.1");

    assert(configuration.application.data.host.name == "127.0.0.1");
    assert(configuration.application.data.host.port == to!short(5432));
    assert(configuration.application.data.database == "PostgreSQL");
    assert(configuration.application.data.credentials.username == "admin");
    assert(configuration.application.data.credentials.password == "password");

    assert(configuration.application.assets.directory == "public");
    assert(configuration.application.assets.files == "*");

    assert(configuration.application.logging.level == "debug");
    assert(configuration.application.logging.path == "log/test.log");
}

unittest
{
    auto configuration = new Configuration!(App)();
    assert(configuration.path == "configuration.json"); //don't init, just make sure the default path is in place
}

version(unittest)
{
    struct AnotherApp
    {
        string name;
    }
}

unittest
{
    //Make sure the terse switches work
    auto configuration = new Configuration!(AnotherApp)(["_", "-e", "development", "-p", "fixtures/environments"]);
    configuration.initialize();
    assert(configuration.application.name == "development environment");
}

unittest
{
    //Make sure the verbose switches work
    auto configuration = new Configuration!(AnotherApp)(["_", "--environment", "development", "--path", "fixtures/environments"]);
    configuration.initialize();
    assert(configuration.application.name == "development environment");
}
