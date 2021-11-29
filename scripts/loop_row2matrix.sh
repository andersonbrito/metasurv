#!/bin/bash

start_date="2021-09-26"
end_date="2021-11-06"

python ../scripts/rows2matrix.py --input metadata.tsv --xvar date --xtype time --yvar variant_lineage --format integer --extra-column country --filter "country:Brazil-North" --start-date $start_date --end-date $end_date --output pango_counts_north.tsv
python ../scripts/rows2matrix.py --input metadata.tsv --xvar date --xtype time --yvar variant_lineage --format integer --extra-column country --filter "country:Brazil-Northeast" --start-date $start_date --end-date $end_date --output pango_counts_northeast.tsv
python ../scripts/rows2matrix.py --input metadata.tsv --xvar date --xtype time --yvar variant_lineage --format integer --extra-column country --filter "country:Brazil-Center West" --start-date $start_date --end-date $end_date --output pango_counts_centerwest.tsv
python ../scripts/rows2matrix.py --input metadata.tsv --xvar date --xtype time --yvar variant_lineage --format integer --extra-column country --filter "country:Brazil-Southeast" --start-date $start_date --end-date $end_date --output pango_counts_southeast.tsv
python ../scripts/rows2matrix.py --input metadata.tsv --xvar date --xtype time --yvar variant_lineage --format integer --extra-column country --filter "country:Brazil-South" --start-date $start_date --end-date $end_date --output pango_counts_south.tsv
python ../scripts/rows2matrix.py --input metadata.tsv --xvar date --xtype time --yvar variant_lineage --format integer --extra-column region --filter "region:South America" --start-date $start_date --end-date $end_date --output pango_counts_brazil.tsv
