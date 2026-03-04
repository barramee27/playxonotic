# Antigravity - QC Makefile
# Requires gmqcc (Xonotic's QuakeC compiler)

GMQCC     ?= gmqcc
GAME_DIR   = ../..
DATA_OUT   = $(GAME_DIR)/antigravity-game/data
PROGS_DAT  = $(DATA_OUT)/progs.dat
CSPROGS_DAT = $(DATA_OUT)/csprogs.dat

GMQCC_FLAGS = -std=gmqcc -Wall -Werror -O2

all: server client

server: $(PROGS_DAT)
client: $(CSPROGS_DAT)

$(PROGS_DAT): server/main.qc
	@mkdir -p $(DATA_OUT)
	$(GMQCC) $(GMQCC_FLAGS) \
		-config server/server.cfg \
		-o $@ \
		server/main.qc
	@echo "Server QC compiled: $@"

$(CSPROGS_DAT): client/main.qc
	@mkdir -p $(DATA_OUT)
	$(GMQCC) $(GMQCC_FLAGS) \
		-config client/client.cfg \
		-o $@ \
		client/main.qc
	@echo "Client QC compiled: $@"

clean:
	rm -f $(PROGS_DAT) $(CSPROGS_DAT)

.PHONY: all server client clean
