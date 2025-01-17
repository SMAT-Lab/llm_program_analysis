package metric
from apm_sdk import api.metric.*
from apm_sdk import api.*
from apm_sdk import exporter.metric.*
from apm_sdk import sdk.common.config.*
from apm_sdk import sdk.resource.SdkResource
from apm_sdk import sdk.common.log.*
from apm_sdk import sdk.metric.*
from apm_sdk import sdk.*
from std import log.LogLevel
from std import collection.{HashMap, ArrayList}
from std import sync.sleep
from std import time.{Duration, DurationExtension}
from apm_sdk import api.resource.Attributes
import config.*
from std import random.*
public class Metric {
    public var telemetry: OpenTelemetry
    public init() {
        telemetry = TelemetryConfig.openTelemetry
    }
    public func start() {
        let array = ArrayList<Int64>()
        let meter = telemetry.getMeter("io.open.oelemetry")
        let histogram = meter.histogramBuilder("test.histogram").ofLongs().setUnit("4").setDescription("histogram test").
            build()
        let upDownCounter = meter.upDownCounterBuilder("test.up.down").ofDoubles().setUnit("3").setDescription(
            "up down test").build()
        let processCounter = meter.counterBuilder("process").setUnit("2").setDescription("process test").build()
        meter.gaugeBuilder("array.size").ofLongs().setUnit("1").setDescription("array size").callback(
            {
                measurement => measurement.record(array.size, Attributes.of("array", "apm").addFloat("aa", 100.0))
            }
        )
        let responseTimeAvg = MetricHolder<IDoubleCounter>.get(MetricConst.RESPONSE_TIME_AVG.key)
        let requestActiveMaxTime = MetricHolder<IDoubleCounter>.get(MetricConst.REQUEST_ACTIVE_MAX_TIME.key)
        let requestActiveTotalCount = MetricHolder<ILongCounter>.get(MetricConst.REQUEST_ACTIVE_TOTAL_COUNT.key)
        let requestFailed = MetricHolder<ILongCounter>.get(MetricConst.REQUEST_FAILED.key)
        upDownCounter.add(100.1, Attributes.of("updown", true))
        processCounter.add(1, Attributes.of("tttttt", "11111"))
        array.append(1)
        let random = Random()
        for (x in 0..10) {
            //模拟silo拦截器用开始
            requestActiveMaxTime.calculate(Float64(x * random.nextInt64(500)), CalculateType.MAX)
            responseTimeAvg.calculate(Float64(x * random.nextInt64(1000)), CalculateType.AVG)
            requestFailed.add(x * random.nextInt64(5))
            requestActiveTotalCount.add(x * random.nextInt64(200))
            //模拟silo拦截器用结束
            histogram.record(x * random.nextInt64(100), Attributes.of("random", true))
            array.append(x)
            sleep(500 * Duration.millisecond)
        }
        spawn {
             =>
            processCounter.add(1, Attributes.of("aaaa", "11111"))
            processCounter.add(2, Attributes.of("bbbb", "11111"))
            sleep(1 * Duration.second)
            array.remove(0)
            array.remove(1)
            upDownCounter.add(-88.2, Attributes.of("updown", true))
            processCounter.add(2, Attributes.of("cccc", "11111"))
            processCounter.add(2, Attributes.of("dddd", "11111"))
            sleep(1 * Duration.second)
            processCounter.add(3, Attributes.of("eeee", "11111"))
            processCounter.add(2, Attributes.of("ffff", "11111"))
            histogram.record(10 * random.nextInt64(100), Attributes.of("random", false))
            sleep(1 * Duration.second)
            processCounter.add(4, Attributes.of("gggg", "11111"))
            processCounter.add(2, Attributes.of("hhhh", "11111"))
            sleep(1 * Duration.second)
            processCounter.add(5, Attributes.of("iiii", "11111"))
            processCounter.add(2, Attributes.of("kkkk", "11111"))
            sleep(1 * Duration.second)
            processCounter.add(2, Attributes.of("vvvvv", "33333"))
            upDownCounter.add(20.2, Attributes.of("updown", true))
        }
        sleep(10 * Duration.second)
    }
}