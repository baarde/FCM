import FCM

extension FCMConfiguration {
    static let testing = FCMConfiguration.testing(email: "testing@test.aim.gserviceaccount.com")
    
    static func testing(email: String) -> FCMConfiguration {
        FCMConfiguration(
            email: email,
            projectId: "test",
            key: """
            -----BEGIN PRIVATE KEY-----
            MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCq2nhnp0uox5Yj
            qEfv7BWYFD1VsyI+NksQSEp0lv2Jmq2DjtE3x7YklWCJimUXSpsRkuuTSfZigLvq
            nWpC4v0YpYJcCwF2/MET2K9Qs0+qetETTb3JAuyPH7obC+gEtKQ5D5ZqSBHGy2xH
            2kdCNIxH4fKqLcSR4IbzsXU10dARGyTugKpeVZ67FmcSxZtvEQIXwrCoKRVi8h78
            aiaEGl6PWjPEp2tTo1iSHixfcEXAaqFtYjiZAcoYcVITR7dCmIj66Dxu2tHYWWgY
            wMGL7d8VIADgtxJgt7lb1Bu6YuFxehM21N4jJFCSfJSwtzJXSAPCA/OH+VCCMirj
            q760//u/AgMBAAECggEAAQeeECne9950FjTuchC/NJJyqDCTNULIgwmcgUVjs8+d
            2hwjQK3QeDn6Qfn2kARgGOQEzXd1p7RU7Z4TROHvWpWsync6hAgT9dWpgNgD0+g3
            mGEwkqSU3mv3iDAzLswT7VAdvPhAOy2AspIrOcftTIWdG894ztRGm/Nm3HMuSNwZ
            e8PChu3fCa0CzQSmlHDBOjY0a+chl9T+3tBPaKjeTtgr2dhdSO45qlqaZFewWXJF
            e6lgn49MpfsAQt22ohSurts40uOv+BDdX6eSEeN19PLgFbQ41adKfrpz2qBWAIga
            tGYTwLuvcIXWnvaweI2G1vAkdUyVWl/xjNq+U64pSQKBgQDsDVWHiRHW2/UE/CL/
            gTsEJvjZIFERYNrtwSNhYH+M+XVjrKWxo+6MLZ+A4O4MWfgz4x0wUFW+L7r2I7iF
            KG/377OC6xWrhOL23oWdB+yWfr55eP6Y/HD15F+Z3dUR6H4i6kgdfykgyI6TepX3
            phtdjznPWMbnXcaGDibEmd6xvQKBgQC5Sqa7/Ipx97oGr/FKNY7qhOxt0gRpyK0Y
            ui/xOsG5yro8UOZruRjeKf3cyPzqPoKtGPE+HfKN/vma40MLWXfJukE+849y9j5r
            tMIgVFmGii0C0SmK+Jw3dtdKEt8QblfQ3TfAw3RFCo9J7VdjXZIlkrhiw5XLrkYa
            RXNcV7w1KwKBgH+Z+akppHYUMxA9yCF8V024T3735DrTs6UgaaLDClBHrXhzJKKx
            bktigj2l2ajdnblWxTmPw7nqjVNvHdkFcfmCHvTfZbhxPkubIHkxhmgYHZkGmgJT
            PDEAAdnoO7zRhBYVtWQUkEQDhmcctiLILTTXLrXyVJtPavief8B5ORO1AoGAUPQd
            nro6XoqmGu/Z0ttNgobqqRx90x3bCpemBJXwN9Urwthxo5TuGXptMH4bidgfzbK9
            C6+X3pQMx7ANBbNkE52tjexpuwd8xB/oRKm1p4NNIRLzPIVb8xuX+gP+szYSZe2Q
            w0Zh0RxI+Dqa2I30IThWGMhs9N1CQY4gVbL7RpsCgYEAlUvnGI3YOMtb9COd5SrM
            B/X+A9wifXF9+cTgngCdprJYv+VekWUSWa+jrMTbC2jURTtuOZzqgqNVdKNmfeUG
            YntMAgkUKphW58LC5uU8VziNp686h40AQXQHAKXz984MWB1PpQgUria3ArYXlI0D
            rG5mv3FiiqQSimO0AMir0JQ=
            -----END PRIVATE KEY-----
            """
        )
    }
}
