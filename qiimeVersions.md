# QIIME2 Current Version

## Most Recent Amplicon Distro: 2024.10-Amplicon

```shell
# Activate qiime2 inside of HPRC
module purge
module load QIIME2/2024.10-Amplicon
```

### Preventing Python Cache Issues on HPRC
If you run into numpy or numba cache issues when running qiime commands on HPRC please run the following.

```shell
export PYTHONNOUSERSITE=1
mkdir -p numba_cache
export NUMBA_CACHE_DIR=./numba_cache
```
