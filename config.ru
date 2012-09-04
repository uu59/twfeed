#!/usr/bin/env rackup
# encoding: utf-8

require File.expand_path("../config/boot.rb", __FILE__)

# app/app.rb
run MyApp
ENV["consumer"] =  "9DI8YHRaYkZaiEcOxMTag"
ENV["consumer_secret"] =  "Bf7NtCv7SyBhGNvTuRxUnzfzojXgEixY4L3i8dfkT0"
