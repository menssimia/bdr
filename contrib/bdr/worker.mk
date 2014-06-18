# contrib/bdr/worker.mk

MODULE_big = bdr
OBJS = \
	bdr.o \
	bdr_apply.o \
	bdr_catalogs.o \
	bdr_conflict_handlers.o \
	bdr_conflict_logging.o \
	bdr_compat.o \
	bdr_commandfilter.o \
	bdr_count.o \
	bdr_executor.o \
	bdr_init_replica.o \
	bdr_locks.o \
	bdr_relcache.o \
	bdr_seq.o

EXTENSION = bdr
DATA = bdr--0.5.sql
DOCS = bdr.conf.sample README.bdr

SCRIPTS = scripts/bdr_initial_load

PG_CPPFLAGS = -I$(libpq_srcdir)
SHLIB_LINK = $(libpq)
SHLIB_PREREQS = submake-libpq

ifdef USE_PGXS
PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
else
subdir = contrib/bdr
top_builddir = ../..
include $(top_builddir)/src/Makefile.global
include $(top_srcdir)/contrib/contrib-global.mk
endif

# Disabled because these tests require "wal_level=logical", which
# typical installcheck users do not have (e.g. buildfarm clients).
installcheck:;

submake-regress:
	$(MAKE) -C $(top_builddir)/src/test/regress

submake-btree_gist:
	$(MAKE) -C $(top_builddir)/contrib/btree_gist

check: all | submake-regress submake-btree_gist regresscheck

REGRESS_DDL_CHECKS=ddl/create ddl/alter_table

regresscheck:
	$(pg_regress_check) \
	    --temp-config $(top_srcdir)/contrib/bdr/bdr_ddlregress.conf \
	    --temp-install=./tmp_check \
	    --extra-install=contrib/btree_gist \
	    --extra-install=contrib/bdr \
	    $(REGRESS_DDL_CHECKS)

PHONY: submake-regress
