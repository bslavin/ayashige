#!/usr/bin/env ruby

$LOAD_PATH.unshift("#{__dir__}/../lib")

require "ayashige"

Ayashige::Jobs::WebAnalyzer.new.perform
