include(ExternalProject)

# dpdk
# note: we have no choice but to use a customized version of dpdk provided
# by mtcp.
set(DPDK_TARGET x86_64-native-linuxapp-gcc CACHE STRING "The DPDK Target")
set(DPDK_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/submodules/mtcp/dpdk-17.08)
set(DPDK_BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/ExternalProject/dpdk)
set(DPDK_INSTALL_DIR ${DPDK_BINARY_DIR})
set(DPDK_INCLUDE_DIR ${DPDK_INSTALL_DIR}/include/dpdk)
set(DPDK_LIB_DIR ${DPDK_INSTALL_DIR}/lib)
file(MAKE_DIRECTORY ${DPDK_SOURCE_DIR}/${DPDK_TARGET}/include)
file(MAKE_DIRECTORY ${DPDK_SOURCE_DIR}/${DPDK_TARGET}/lib)
set(DPDK_LIBS
  libdpdk.a
  librte_acl.a
  librte_bitratestats.a
  librte_cfgfile.a
  librte_cmdline.a
  librte_cryptodev.a
  librte_distributor.a
  librte_eal.a
  librte_efd.a
  librte_ethdev.a
  librte_eventdev.a
  librte_gro.a
  librte_hash.a
  librte_ip_frag.a
  librte_jobstats.a
  librte_kni.a
  librte_kvargs.a
  librte_latencystats.a
  librte_lpm.a
  librte_mbuf.a
  librte_mempool.a
  librte_mempool_ring.a
  librte_mempool_stack.a
  librte_meter.a
  librte_metrics.a
  librte_net.a
  librte_pdump.a
  librte_pipeline.a
  librte_pmd_af_packet.a
  librte_pmd_ark.a
  librte_pmd_avp.a
  librte_pmd_bnxt.a
  librte_pmd_bond.a
  librte_pmd_crypto_scheduler.a
  librte_pmd_cxgbe.a
  librte_pmd_e1000.a
  librte_pmd_ena.a
  librte_pmd_enic.a
  librte_pmd_failsafe.a
  librte_pmd_fm10k.a
  librte_pmd_i40e.a
  librte_pmd_ixgbe.a
  librte_pmd_kni.a
  librte_pmd_lio.a
  librte_pmd_mlx5.a
  librte_pmd_nfp.a
  librte_pmd_null.a
  librte_pmd_null_crypto.a
  librte_pmd_octeontx_ssovf.a
  librte_pmd_qede.a
  librte_pmd_ring.a
  librte_pmd_sfc_efx.a
  librte_pmd_skeleton_event.a
  librte_pmd_sw_event.a
  librte_pmd_tap.a
  librte_pmd_thunderx_nicvf.a
  librte_pmd_vhost.a
  librte_pmd_virtio.a
  librte_pmd_vmxnet3_uio.a
  librte_port.a
  librte_power.a
  librte_reorder.a
  librte_ring.a
  librte_sched.a
  librte_table.a
  librte_timer.a
  librte_vhost.a
)
ExternalProject_Add(dpdk
  PREFIX ${DPDK_BINARY_DIR}
  SOURCE_DIR ${DPDK_SOURCE_DIR}
  CONFIGURE_COMMAND make -C ${DPDK_SOURCE_DIR} config  T=${DPDK_TARGET}
  BUILD_COMMAND make -C ${DPDK_SOURCE_DIR} T=${DPDK_TARGET}
  INSTALL_COMMAND make -C ${DPDK_SOURCE_DIR} install T=${DPDK_TARGET} DESTDIR=${DPDK_INSTALL_DIR}
)
function(target_add_dpdk TARGET)
  target_link_libraries(${TARGET} ${DPDK_LIBS})
  target_include_directories(${TARGET} PUBLIC ${DPDK_INCLUDE_DIR})
  set_target_properties(${TARGET} PROPERTIES
    COMPILE_FLAGS "-march=native -DRTE_MACHINE_CPUFLAG_SSE -DRTE_MACHINE_CPUFLAG_SSE2 -DRTE_MACHINE_CPUFLAG_SSE3 -DRTE_MACHINE_CPUFLAG_SSSE3 -DRTE_MACHINE_CPUFLAG_SSE4_1 -DRTE_MACHINE_CPUFLAG_SSE4_2"
    LINK_FLAGS "-lrt -lm -lnuma -ldl -libverbs -L${DPDK_LIB_DIR}"
  )
  add_dependencies(${TARGET} dpdk)
endfunction(target_add_dpdk)

# mtcp
set(MTCP_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/submodules/mtcp)
set(MTCP_BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/ExternalProject/mtcp)
set(MTCP_LIBS ${MTCP_SOURCE_DIR}/mtcp/lib/libmtcp.a)
ExternalProject_Add(mtcp
  PREFIX ${MTCP_BINARY_DIR}
  DEPENDS dpdk
  SOURCE_DIR ${MTCP_SOURCE_DIR}
  CONFIGURE_COMMAND cd ${MTCP_SOURCE_DIR} &&  ./configure --with-dpdk-lib=${DPDK_SOURCE_DIR}/${DPDK_TARGET} CFLAGS=-I${CMAKE_CURRENT_SOURCE_DIR}
  BUILD_COMMAND make -C ${MTCP_SOURCE_DIR}
  INSTALL_COMMAND echo 'MTCP doesn't support an install step'
)
function(target_add_mtcp TARGET)
  target_link_libraries(${TARGET} ${MTCP_LIBS})
  target_include_directories(${TARGET} PUBLIC ${MTCP_SOURCE_DIR}/mtcp/include)
  add_dependencies(${TARGET} mtcp)
  # note: this must follow `target_link_libraries()` or link errors
  # will manifest!
  target_add_dpdk(${TARGET})
endfunction(target_add_mtcp)
