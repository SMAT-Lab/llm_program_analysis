package compress4cj.compressors.bzip2
public interface BZip2Constants {
    static prop BASEBLOCKSIZE: Int64 {
        get() {
            100000
        }
    }
    static prop MAX_ALPHA_SIZE: Int64 {
        get() {
            258
        }
    }
    static prop MAX_CODE_LEN: Int64 {
        get() {
            23
        }
    }
    static prop RUNA: Int64 {
        get() {
            0
        }
    }
    static prop RUNB: Int64 {
        get() {
            1
        }
    }
    static prop N_GROUPS: Int64 {
        get() {
            6
        }
    }
    static prop G_SIZE: Int64 {
        get() {
            50
        }
    }
    static prop N_ITERS: Int64 {
        get() {
            4
        }
    }
    static prop MAX_SELECTORS: Int64 {
        get() {
            2 + (900000 / G_SIZE)
        }
    }
    static prop NUM_OVERSHOOT_BYTES: Int64 {
        get() {
            20
        }
    }
}