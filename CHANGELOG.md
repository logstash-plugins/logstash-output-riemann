## 3.0.7
  - Updated riemann-client gem to 0.2.6 to benefit timeout support [#26](https://github.com/logstash-plugins/logstash-output-riemann/pull/26)

## 3.0.6
  - Fix values from "riemann_event" not overwriting those from "map_fields".
    [#22](https://github.com/logstash-plugins/logstash-output-riemann/issues/22)
  - Fix ttl, metric sometimes being sent as string, not float.
    [#23](https://github.com/logstash-plugins/logstash-output-riemann/issues/23)

## 3.0.5
  - Fix formatting in doc for conversion to --asciidoctor [#21](https://github.com/logstash-plugins/logstash-output-riemann/pull/21)

## 3.0.4
  - Docs: Set the default_codec doc attribute.

## 3.0.3
  - Update gemspec summary

## 3.0.2
  - Fix some documentation issues

## 3.0.0
  - Breaking: Updated plugin to use new Java Event APIs
  - relax logstash-core-plugin-api constrains
  - update .travis.yml

## 2.0.5
  - Depend on logstash-core-plugin-api instead of logstash-core, removing the need to mass update plugins on major releases of logstash

## 2.0.4
  - New dependency requirements for logstash-core for the 5.0 release

## 2.0.3
 - Fix: when using `map_fields` with `sender` hostname would not be properly set

## 2.0.0
 - Plugins were updated to follow the new shutdown semantic, this mainly allows Logstash to instruct input plugins to terminate gracefully, 
   instead of using Thread.raise on the plugins' threads. Ref: https://github.com/elastic/logstash/pull/3895
 - Dependency on logstash-core update to 2.0
