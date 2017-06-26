primitive FrameVisitor is Visitor[Frame]

    fun ref apply(frame: Frame, collector: Stack ref): Stack ref =>
        collector
