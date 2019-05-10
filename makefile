DOCKER_REGISTRY := mathematiguy
IMAGE_NAME := $(shell basename `git rev-parse --show-toplevel`)
IMAGE := $(DOCKER_REGISTRY)/$(IMAGE_NAME)
RUN ?= docker run $(DOCKER_ARGS) --rm -v $$(pwd):/work -w /work -u $(UID):$(GID) $(IMAGE)
UID ?= $(shell id -u)
GID ?= $(shell id -g)
DOCKER_ARGS ?= 
GIT_TAG ?= $(shell git log --oneline | head -n1 | awk '{print $$1}')

all: docker htmls pdfs

htmls: bayes-time-series.html \
	outline/overall-outline.html \
	bsts-level-1.html

pdfs: bayes-time-series.pdf \
	outline/overall-outline.pdf \
	bsts-pres.pdf \
	bsts-level-1.pdf \
	bsts-level-0.pdf \
	bsts-implement-forecasting.pdf \
	Presentations/SST/SST_pres.pdf \
	Presentations/SST/SST_pres_ttucker_edits.pdf \
	Presentations/Intro/intro_pres.pdf \
	Presentations/Intro/intro_script.pdf \
	Presentations/Structural-Bayes/struct_ts_bayes_script.pdf \
	Presentations/Structural-Bayes/struct_ts_bayes.pdf \
	Presentations/Structural/struct_ts_script.pdf \
	Presentations/Structural/struct_ts_pres.pdf \
	Presentations/SST-Regression/sst_reg_pres.pdf

%.html: %.Rmd
	$(RUN) bash -c "cd $(dir $<) && Rscript -e \"rmarkdown::render('$(notdir $*.Rmd)')\""

%.pdf: %.Rmd
	$(RUN) bash -c "cd $(dir $<) && Rscript -e \"rmarkdown::render('$(notdir $*.Rmd)')\""

clean:
	find . -name '*_cache' -type d | xargs rm -rf
	find . -name '*_files' -type d | xargs rm -rf
	find . -name '*.log' -type d | xargs rm -rf
	find . -name '*.Rmd' | sed 's/Rmd$$/tex/g' | xargs rm -f
	
clean_outputs:
	find . -name '*.Rmd' | sed 's/Rmd$$/pdf/g' | xargs rm -f
	find . -name '*.Rmd' | sed 's/Rmd$$/html/g' | xargs rm -f

.PHONY: docker
docker:
	docker build --tag $(IMAGE):$(GIT_TAG) .
	docker tag $(IMAGE):$(GIT_TAG) $(IMAGE):latest

.PHONY: docker-push
docker-push:
	docker push $(IMAGE):$(GIT_TAG)
	docker push $(IMAGE):latest

.PHONY: docker-pull
docker-pull:
	docker pull $(IMAGE):$(GIT_TAG)
	docker tag $(IMAGE):$(GIT_TAG) $(IMAGE):latest

.PHONY: enter
enter: DOCKER_ARGS=-it
enter:
	$(RUN) bash

.PHONY: enter-root
enter-root: DOCKER_ARGS=-it
enter-root: UID=root
enter-root: GID=root
enter-root:
	$(RUN) bash
