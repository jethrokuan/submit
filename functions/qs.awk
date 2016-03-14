function qsort(A, L, R, pivot,   j, i, t) {
    pivot = j = i = t

    if (L >= R) {
        return
    }

    pivot = L
    i = L
    j = R

    while (i < j) {
        while (A[i] <= A[pivot] && i < R) i++
        while (A[j] > A[pivot]) j--
        if (i < j) {
            t = A[i]
            A[i] = A[j]
            A[j] = t
        }
    }

    t = A[pivot]
    A[pivot] = A[j]
    A[j] = t

    qsort(A, L, j - 1)
    qsort(A, j + 1, R)
}

{
    A[NR] = $1
    K[$1] = $0
}

END {
    qsort(A, 1, NR)

    for (i = 1; i < NR; i++) {
        printf("%s\n\n", K[A[i]])
    }
    
    printf("%s\n", K[A[NR]])
}
