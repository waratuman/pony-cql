primitive StartupRequestParser is Parser[StartupRequest]

    fun box apply(data: Seq[U8 val] ref): StartupRequest iso^ ? =>
        let map = StringMapParser(data)?

        recover iso
            if map.contains("COMPRESSION") then
                StartupRequest(map("CQL_VERSION")?, map("COMPRESSION")?)
            else
                StartupRequest(map("CQL_VERSION")?)
            end
        end

