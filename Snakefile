rule arguments:
	params:
		metadata = "data/metadata_nextstrain.tsv",
		case_data = "data/time_series_covid19_brazil_reformatted.tsv",
		index_column = "division",
		date_column = "date",
		time_unit = "week",
		start_date = "2019-12-15",
		end_date = "2021-09-18",
		download = "yes"


arguments = rules.arguments.params

rule epidata:
	message:
		"""
		Download case data from Brazil
		"""
	params:
		xvar = "date",
		xtype = "time",
		target_column = "newCases",
		yvar = "state",
		start = arguments.start_date,
		end = arguments.end_date
	output:
		data = "outputs/time_series_covid19_brazil.csv",
		matrix = arguments.case_data
	shell:
		"""
		wget "https://raw.githubusercontent.com/wcota/covid19br/master/cases-brazil-states.csv"
		mv "cases-brazil-states.csv" {output.data}

		python3 scripts/rows2matrix.py \
			--input {output.data} \
			--xvar {params.xvar} \
			--xtype {params.xtype} \
			--target {params.target_column} \
			--yvar {params.yvar} \
			--start-date {params.start} \
			--end-date {params.end} \
			--output {output.matrix}
		"""



rule genome_matrix:
	message:
		"""
		Generate matrix of genome counts per day, for each element in column="{arguments.index_column}"
		"""
	input:
		metadata = arguments.metadata
	params:
		index = arguments.index_column,
		id = "state",
		extra_columns = "country",
		date = arguments.date_column,
		filter_value = "country:Brazil"
	output:
		matrix = "outputs/genome_matrix_days.tsv"
	shell:
		"""
		python3 scripts/get_genome_matrix_br.py \
			--metadata {input.metadata} \
			--index-column {params.index} \
			--new-index {params.id} \
			--extra-columns {params.extra_columns} \
			--filter {params.filter_value} \
			--date-column {params.date} \
			--output {output.matrix}
		"""


rule aggregate:
	message:
		"""
		Generate matrix of genome and case counts per unit of time
		"""
	input:
		genome_matrix = "outputs/genome_matrix_days.tsv",
		case_matrix = arguments.case_data
	params:
		unit = arguments.time_unit,
		start_date = "2020-02-22"
	output:
		output1 = "outputs/matrix_genomes_aggregated.tsv",
		output2 = "outputs/matrix_cases_aggregated.tsv"
	shell:
		"""
		python3 scripts/aggregator.py \
			--input {input.genome_matrix} \
			--unit {params.unit} \
			--output {output.output1}

		python3 scripts/aggregator.py \
			--input {input.case_matrix} \
			--start-date {params.start_date} \
			--unit {params.unit} \
			--output {output.output2}
		"""


rule get_rates:
	message:
		"""
		Normalize data matrix, against another matrix or using constant, fixed values
		"""
	input:
		matrix1 = "outputs/matrix_genomes_aggregated.tsv",
		matrix2 = "outputs/matrix_cases_aggregated.tsv"
	params:
		index = "state"
	output:
		output = "outputs/genome_sampling_proportions.tsv"
	shell:
		"""
		python3 scripts/normdata.py \
			--input1 {input.matrix1} \
			--input2 {input.matrix2} \
			--index {params.index} \
			--output {output.output}
		"""


rule clean:
	message: "Removing directories: {params}"
	params:
		"outputs"

	shell:
		"""
		rm -rfv {params}
		"""
