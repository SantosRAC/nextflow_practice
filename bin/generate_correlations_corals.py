#!/usr/bin/env python

import argparse
import pandas as pd

from corals.threads import set_threads_for_external_libraries
set_threads_for_external_libraries(n_threads=1)
import numpy as np
from corals.correlation.topk.default import cor_topk

parser = argparse.ArgumentParser(description='Generate correlations with corALS')
parser.add_argument('--expression_matrix', type=str, dest='expression_file',
                    help='Expression file', metavar="matrix.tsv",
                    required=True)
parser.add_argument('--output_network', type=str, dest='output_network',
                    help='Network file', metavar="network.txt",
                    required=True)
args = parser.parse_args()

matrix_file = args.expression_file
output_network = args.output_network

expression_matrix = pd.read_csv(matrix_file, sep="\t", index_col=0)
expression_matrix_transposed = expression_matrix.transpose()
expression_matrix_transposed_filtered= expression_matrix_transposed.loc[:, expression_matrix_transposed.sum(axis=0) != 0]

gene_names=expression_matrix_transposed_filtered.columns.to_list()
cor_topk_result = cor_topk(expression_matrix_transposed_filtered, k=0.05, correlation_type="pearson", n_jobs=3)

with open(args.output_network, 'w') as out:
    for i, j, v in zip(cor_topk_result[1][0], cor_topk_result[1][1], cor_topk_result[0]):
        out.write(f"{gene_names[i]}\t{gene_names[j]}\t{v}\n")