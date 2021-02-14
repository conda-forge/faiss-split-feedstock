# same build script, only difference through CF_FAISS_BUILD
cp ${RECIPE_DIR}/build-lib.sh .
export CF_FAISS_BUILD="generic"
bash build-lib.sh
