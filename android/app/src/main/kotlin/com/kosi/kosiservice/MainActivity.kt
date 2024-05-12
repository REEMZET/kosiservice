package com.kosi.kosiservice

import io.flutter.embedding.android.FlutterActivity
import android.os.Bundle
import com.google.firebase.analytics.FirebaseAnalytics

class MainActivity: FlutterActivity() {
    private lateinit var mFirebaseAnalytics: FirebaseAnalytics

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // ...

        // Initialize Firebase Analytics
        mFirebaseAnalytics = FirebaseAnalytics.getInstance(this)

        // Define values for "image_name" and "full_text"
        val name = "KosiService"
        val text = "YourFullText"

        // Create a Bundle with event parameters
        val params = Bundle()
        params.putString("image_name", name)
        params.putString("full_text", text)

        // Log the "share_image" event with parameters
        mFirebaseAnalytics.logEvent("share_image", params)
    }
}
