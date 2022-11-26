OUTPUT_SCRIPT_NAME 	?= module
NAMESPACE			?= module

OUTPUT_DIR			?= .
BUILD_DIR			?= ./build
LIB_DIR				?= ./lib
SRC_DIR				?= ./src
RES_DIR				?= ./res

LIBS 				:= $(wildcard ${LIB_DIR}/*)
SRCS 				:= $(wildcard ${SRC_DIR}/*)
RES					:= $(wildcard ${RES_DIR}/*)

OUTPUT_BIN			:= $(OUTPUT_DIR)/$(OUTPUT_SCRIPT_NAME)

.phony: build install clean

default: install

build: 
	@echo "Building 	: $(OUTPUT_SCRIPT_NAME)"
	@echo "Build Dir 	: $(BUILD_DIR)"
	@echo "Source   	: $(SRC_DIR)"
	@echo "Libraries	: $(LIB_DIR)"
	@echo "Resources	: $(RES_DIR)"
	@echo "Output   	: $(OUTPUT_DIR)/$(OUTPUT_SCRIPT_NAME)"

	@mkdir -p $(BUILD_DIR)
	@make replace_tokens
	@make combine_all

install: clean build

clean:
	@rm -rf $(BUILD_DIR) $(OUTPUT_BIN)

combine_all: $(BUILD_DIR)/*
	@rm -f $(OUTPUT_BIN)

	@for f in $^ ; do \
		echo "Concatting $$f to $(OUTPUT_BIN)" ; \
		cat $$f >> $(OUTPUT_BIN) ; \
	 done

replace_tokens: $(LIBS) $(SRCS) $(RES)
	@for f in $^ ; do \
		dest="$(BUILD_DIR)/$$(basename $$f)" ; \
		echo "Processing $$f >> $$dest" ; \
		cp $$f $$dest ; \
		sed -i "s|__BEGIN_SOURCE__|#---------] Begin $$f  [--------|g" $$dest ; \
		sed -i "s|__END_SOURCE__|#---------] End $$f [--------|g" $$dest ; \
		sed -i "s|__NAMESPACE__|$(NAMESPACE)|g" $$dest ; \
	done

