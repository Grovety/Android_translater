package com.example.multilingual_app

import android.content.Context
import android.graphics.Color
import android.view.View
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import io.flutter.plugin.common.StandardMessageCodec


class TransparentViewFactory : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, id: Int, args: Any?): PlatformView {
        return TransparentPlatformView(context)
    }
}

class TransparentPlatformView(private val context: Context) : PlatformView {
    override fun getView(): View {
        return View(context).apply {
            setBackgroundColor(Color.TRANSPARENT)
        }
    }

    override fun dispose() {}
}