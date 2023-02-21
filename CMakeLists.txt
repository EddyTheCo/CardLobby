cmake_minimum_required(VERSION 3.16)

project(IOTA VERSION 0.1 LANGUAGES CXX)
set(CMAKE_AUTOMOC ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Quick)

include(local_conf.cmake OPTIONAL)


qt6_add_qml_module(cardLobby
    URI  cardLobby
    VERSION 1.0
    SOURCES
    include/
    QML_FILES
    qml/CardLobby.qml
    qml/OpponentDetail.qml
    RESOURCE_PREFIX
    "/esthertech.com/imports"
    OUTPUT_TARGETS out_targets_var
    IMPORTS  bout_publisher players_model card_designs
    IMPORT_PATH
    ${CMAKE_BINARY_DIR}/_deps/bout_publisher-build
    ${CMAKE_BINARY_DIR}/_deps/players_model-build
    ${CMAKE_BINARY_DIR}/_deps/card_designs-build
    OUTPUT_DIRECTORY
       ${CMAKE_CURRENT_BINARY_DIR}/cardLobby
)

target_link_libraries(cardLobby PUBLIC Qt6::Gui Qt6::Quick)

include(FetchContent)
FetchContent_Declare(
    players_model
    GIT_REPOSITORY git@github.com:EddyTheCo/Players_Model.git
    GIT_TAG main
)
FetchContent_MakeAvailable(players_model)

FetchContent_Declare(
    bout_publisher
    GIT_REPOSITORY git@github.com:EddyTheCo/BoutPublisher.git
    GIT_TAG main
)
FetchContent_MakeAvailable(bout_publisher)
FetchContent_Declare(
    card_designs
    GIT_REPOSITORY git@github.com:EddyTheCo/CardDesigns.git
    GIT_TAG main
)
FetchContent_MakeAvailable(card_designs)

target_link_libraries(cardLobby PUBLIC bout_publisher  players_model card_designs )

target_compile_definitions(cardLobby
    PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)

install(TARGETS cardLobby ${out_targets_var} EXPORT cardLobbyTargets DESTINATION bin )
install(DIRECTORY include/ DESTINATION include/)

install(EXPORT cardLobbyTargets
    FILE cardLobbyTargets.cmake
    DESTINATION lib/cmake/cardLobby
)
include(CMakePackageConfigHelpers)
# generate the config file that is includes the exports
configure_package_config_file(${CMAKE_CURRENT_SOURCE_DIR}/Config.cmake.in
    "${CMAKE_CURRENT_BINARY_DIR}/cardLobbyConfig.cmake"
    INSTALL_DESTINATION "lib/cmake/cardLobby"
    NO_SET_AND_CHECK_MACRO
    NO_CHECK_REQUIRED_COMPONENTS_MACRO
)
write_basic_package_version_file(
    "${CMAKE_CURRENT_BINARY_DIR}/cardLobbyConfigVersion.cmake"
    VERSION "0.1.1.0"
    COMPATIBILITY AnyNewerVersion
)
install(FILES
    ${CMAKE_CURRENT_BINARY_DIR}/cardLobbyConfig.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/cardLobbyConfigVersion.cmake
    DESTINATION lib/cmake/cardLobby
)
export(EXPORT cardLobbyTargets
    FILE "${CMAKE_CURRENT_BINARY_DIR}/cardLobbyTargets.cmake"
)

list(APPEND QML_IMPORT_PATH ${CMAKE_CURRENT_SOURCE_DIR}/qml ${CMAKE_CURRENT_BINARY_DIR}/)
set(QML_IMPORT_PATH ${QML_IMPORT_PATH}  CACHE STRING "" FORCE)
message(STATUS "cardLobbyQML_IMPORT_PATH:${QML_IMPORT_PATH}")
