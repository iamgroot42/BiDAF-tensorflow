#!/usr/bin/env bash
source_path=$1
target_path=$2
inter_dir="inter_single"
root_dir="save"

parg=""
marg=""
if [ "$3" = "debug" ]
then
    parg="-d"
    marg="--draft"
fi

# Preprocess data
python3 -m squad.prepro --mode single --single_path $source_path -pm $parg --target_dir $inter_dir --glove_dir .

eargs=""
for num in 31 33 34 35 36 37 40 41 43 44 45 46; do
    load_path="$root_dir/$num/save"
    shared_path="$root_dir/$num/shared.json"
    eval_path="$inter_dir/eval-$num.json"
    eargs="$args $eval_path"
    python3 -m basic.cli --data_dir $inter_dir --eval_path $eval_path --nodump_answer --load_path $load_path --shared_path $shared_path $marg --eval_num_batches 0 --mode forward --batch_size 1 --len_opt --cluster --cpu_opt --load_ema &
done
wait

# Ensemble
python3 -m basic.ensemble --data_path $inter_dir/data_single.json --shared_path $inter_dir/shared_single.json -o $target_path $eargs