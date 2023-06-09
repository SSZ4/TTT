package com.a804.tickle_tackle_tockle.complication

import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.util.Log
import com.a804.tickle_tackle_tockle.MainActivity
import com.a804.tickle_tackle_tockle.QRActivity
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage

class FirebaseMessagingService : FirebaseMessagingService() {
    private lateinit var sharedPreferences: SharedPreferences

    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        sharedPreferences = applicationContext.getSharedPreferences("tttToken", Context.MODE_PRIVATE)
        if(sharedPreferences.getString("accessToken",null) == null || sharedPreferences.getString("refreshToken",null) == null ){
            val accessToken = remoteMessage.data["accessToken"]
            val refreshToken = remoteMessage.data["refreshToken"]

            accessToken?.let { accessToken ->
                sharedPreferences.edit().putString("accessToken",accessToken).apply()
            }
            refreshToken?.let { refreshToken ->
                sharedPreferences.edit().putString("refreshToken",refreshToken).apply()
                val intent =
                    if (accessToken != null && refreshToken != null) {
                        Intent(this@FirebaseMessagingService, MainActivity::class.java)
                    } else {
                        Intent(this@FirebaseMessagingService, QRActivity::class.java)
                    }
                intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK)
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                startActivity(intent)
            }
        }
    }
}