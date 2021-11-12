#!/bin/bash


python ../scripts/rows2matrix.py --input metadata.tsv --xvar date --xtype time --yvar variant_lineage --extra-column country --filter "country:Brazil-North" --start-date 2021-09-12 --end-date 2021-10-23 --output pango_counts_north.tsv
python ../scripts/rows2matrix.py --input metadata.tsv --xvar date --xtype time --yvar variant_lineage --extra-column country --filter "country:Brazil-Northeast" --start-date 2021-09-12 --end-date 2021-10-23 --output pango_counts_northeast.tsv
python ../scripts/rows2matrix.py --input metadata.tsv --xvar date --xtype time --yvar variant_lineage --extra-column country --filter "country:Brazil-Center West" --start-date 2021-09-12 --end-date 2021-10-23 --output pango_counts_centerwest.tsv
python ../scripts/rows2matrix.py --input metadata.tsv --xvar date --xtype time --yvar variant_lineage --extra-column country --filter "country:Brazil-Southeast" --start-date 2021-09-12 --end-date 2021-10-23 --output pango_counts_southeast.tsv
python ../scripts/rows2matrix.py --input metadata.tsv --xvar date --xtype time --yvar variant_lineage --extra-column country --filter "country:Brazil-South" --start-date 2021-09-12 --end-date 2021-10-23 --output pango_counts_south.tsv
python ../scripts/rows2matrix.py --input metadata.tsv --xvar date --xtype time --yvar variant_lineage --extra-column country --filter "region:South America" --start-date 2021-09-12 --end-date 2021-10-23 --output pango_counts_brazil.tsv
