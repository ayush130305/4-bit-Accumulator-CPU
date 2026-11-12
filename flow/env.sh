# env.sh - Shared paths for the acc4 / SCL C1D flow. Source it: . flow/env.sh
export PROJ="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"                  # Project root
export SCL="$HOME/scl"                                                             # PDK install root
export PDK_ROOT="$SCL/my_dtech/Open_Source_SCL_1.2micron_PDK_digital/open_source_scl_c1d/open_pdks"  # OpenLane PDK_ROOT
export C1D="$PDK_ROOT/sclc1d/digital_c1d"                                          # Std-cell views
export KTECH="$PDK_ROOT/sclc1d/libs.tech/klayout/tech"                             # KLayout decks
export PADF="$SCL/PadFrame_C1D"                                                    # Pad frame kit
export C1D_V="$C1D/verilog/c1d.v"                                                  # Cell Verilog models
export OL_IMAGE="ghcr.io/the-openroad-project/openlane:ff5509f65b17bfa4068d5336495ab1718987ff69-amd64"  # OpenLane image
# Tools (OpenROAD/OpenSTA source, read_verilog) split paths on spaces, so use a space-free link
[ -e "$HOME/acc4" ] || ln -s "$PROJ" "$HOME/acc4"
export PROJ_NS="$HOME/acc4"                                                        # Space-free project path
