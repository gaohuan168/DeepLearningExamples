logdir="decoding-log"
mkdir ${logdir}
export CUDA_VISIBLE_DEVICES=1
all_log="${logdir}/all-log.log"
echo -e "Type \t Batch_size \t Sequence_length \t DataType \t Time " > $all_log

for batch in 1 32 64 128 256;
do
    # For FP32
    tmp_log=${logdir}/batchsize-${batch}-seq-32-fp32-log.log
    ./bin/decoding_gemm ${batch} 4 8 64 30000 32 768 0
    python decoding_sample.py \
            --batch_size ${batch} \
            --beam_width 4 \
            --max_seq_len 32 \
            --head_number 8 \
            --size_per_head 64 \
            --memory_hidden_dim 768 \
            --num_layer 6 \
            --data_type fp32 \
            --test_time 1 2>&1 | tee ${tmp_log}
    tail ${tmp_log} -n 2 | awk  -v batch_size=$batch  '{print $2 "\t" batch_size "\t" 32 "\t" "FP32" "\t" $5 " " $6 }' >> $all_log

    # For FP16
    tmp_log=${logdir}/batchsize-${batch}-seq-32-fp16-log.log
    ./bin/decoding_gemm ${batch} 4 8 64 30000 32 768 1
    python decoding_sample.py \
            --batch_size ${batch} \
            --beam_width 4 \
            --max_seq_len 32 \
            --head_number 8 \
            --size_per_head 64 \
            --memory_hidden_dim 768 \
            --num_layer 6 \
            --data_type fp16 \
            --test_time 1 2>&1 | tee ${tmp_log}
    tail ${tmp_log} -n 2 | awk  -v batch_size=$batch  '{print $2 "\t" batch_size "\t" 32 "\t" "FP16" "\t" $5 " " $6 }' >> $all_log
done

for sequence_length in 64 128;
do
    # For FP32
    tmp_log=${logdir}/batchsize-1-seq-${sequence_length}-fp32-log.log
    ./bin/decoding_gemm 1 4 8 64 30000 $sequence_length 768 0
    python decoding_sample.py \
            --batch_size 1 \
            --beam_width 4 \
            --max_seq_len $sequence_length \
            --head_number 8 \
            --size_per_head 64 \
            --memory_hidden_dim 768 \
            --num_layer 6 \
            --data_type fp32 \
            --test_time 1 2>&1 | tee ${tmp_log}
    tail ${tmp_log} -n 2 | awk  -v seq=$sequence_length  '{print $2 "\t" 1 "\t" seq "\t" "FP32" "\t" $5 " " $6 }' >> $all_log

    # For FP16
    tmp_log=${logdir}/batchsize-1-seq-$sequence_length-fp16-log.log
    ./bin/decoding_gemm 1 4 8 64 30000 $sequence_length 768 1
    python decoding_sample.py \
            --batch_size 1 \
            --beam_width 4 \
            --max_seq_len $sequence_length \
            --head_number 8 \
            --size_per_head 64 \
            --memory_hidden_dim 768 \
            --num_layer 6 \
            --data_type fp16 \
            --test_time 1 2>&1 | tee ${tmp_log}
    tail ${tmp_log} -n 2 | awk  -v seq=$sequence_length  '{print $2 "\t" 1 "\t" seq "\t" "FP16" "\t" $5 " " $6 }' >> $all_log
done

