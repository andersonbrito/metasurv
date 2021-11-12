#!/bin/bash

python ../scripts/aggregator.py --input pango_counts_north.tsv --unit week --output pango_counts_north_weeks.tsv
python ../scripts/aggregator.py --input pango_counts_northeast.tsv --unit week --output pango_counts_northeast_weeks.tsv
python ../scripts/aggregator.py --input pango_counts_centerwest.tsv --unit week --output pango_counts_centerwest_weeks.tsv
python ../scripts/aggregator.py --input pango_counts_southeast.tsv --unit week --output pango_counts_southeast_weeks.tsv
python ../scripts/aggregator.py --input pango_counts_south.tsv --unit week --output pango_counts_south_weeks.tsv
python ../scripts/aggregator.py --input pango_counts_brazil.tsv --unit week --output pango_counts_brazil_weeks.tsv
