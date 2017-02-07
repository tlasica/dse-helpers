#! /usr/bin/env python

import json
import matplotlib.pyplot as plot
import matplotlib.lines as mlines

description = """
jolokia-plot.py <file> --metrics <metrics>

Examples:
./jolokia-plot.py jolokia.example.multivalue.log --metrics Throughput,FlushMaxTime
./jolokia-plot.py jolokia.example.singlevalue.log

It takes a file with output from jolokia command (json) like
while(sleep 1); do http 'http://localhost:8778/jolokia/read/com.datastax.bdp:type=search,index=demo.geo,name=IndexPool' && echo; done | tee index_pool.json &

so each line is of form:
{"request":{"mbean":"com.datastax.bdp:index=demo.geo,name=MergeMetrics,type=search","arguments":["WARM","50"],"type":"exec",
"operation":"getLatencyPercentile"},"value":35359,"timestamp":1478623267,"status":200}
"""

def main():
    import argparse
    parser = argparse.ArgumentParser(description=description)
    parser.add_argument('file', type=str, help="input file name")
    parser.add_argument("--metrics", help="list of comma separated metrics", type=str, default=None)
    parser.add_argument("--start", help="start in [sec] from beginning to plot", type=long, default=None)
    parser.add_argument("--end", help="end in [sec] from beginning to plot", type=long, default=None)
    args = parser.parse_args()

    parsed_data = parse_file(args.file, args.metrics, min_sec=args.start or 0, max_sec=args.end or 60*60*24*31)
    plot_data(parsed_data)

    return 0


def parse_file(file_path, metrics, min_sec, max_sec):
    if metrics:
        metrics = metrics.split(",")
    output = []
    errors = 0
    total = 0
    start_timestamp = None
    with open(file_path, "rt") as f:
        for line in f:
            total += 1
            data = json.loads(line)
            try:
                values = data['value']
                timestamp = data['timestamp']
                start_timestamp = start_timestamp or timestamp
                point = {'timestamp': timestamp}
                if metrics:
                    for m in metrics:
                        point[m] = values[m]
                else:
                    point['value'] = values
                if min_sec <= (timestamp - start_timestamp) <= max_sec:
                    output.append(point)
            except KeyError:
                errors += 1

    print "Total lines: {total} with {err} errors".format(total=total, err=errors)
    return output


def plot_data(data):
    if not data:
        print "No data found. Terminating without plot"
        return
    start_timestamp = long(data[0]['timestamp'])
    lines = [k for k in data[0].keys() if k != 'timestamp']
    plot.title(", ".join(lines))
    plot.xlabel('duration[sec]')
    timestamps = [long(p['timestamp']) - start_timestamp for p in data]

    styles = list("bgrcmyk")
    styles.reverse()

    series = []

    for line in lines:
        style = styles.pop()
        values = [p[line] for p in data]
        plot.plot(timestamps, values, style)
        series.append( mlines.Line2D(timestamps, values, color=style, label=line))

    plot.legend(handles=series)
    plot.show()

if __name__ == "__main__":
    main()
