.onLoad <- function(lib, pkg) rlang::run_on_load()

rlang::on_load({
	# enable cli formatting for rlang::abort() and rlang::warn()
	# see ?rlang::`topic-condition-formatting`
	rlang::local_use_cli()
})
