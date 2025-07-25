package com.example.bithumb_api_test

import android.os.Bundle
import android.util.Log
import androidx.activity.enableEdgeToEdge
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import com.example.bithumb_api_test.databinding.ActivityResultBinding
import com.example.bithumb_api_test.retrofit.ApiClient
import com.example.bithumb_api_test.retrofit.BithumbApi
import com.example.bithumb_api_test.retrofit.NowPriceResponse
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response

class ResultActivity : AppCompatActivity() {

    private lateinit var binding: ActivityResultBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        binding = ActivityResultBinding.inflate(layoutInflater)
        setContentView(binding.root)

        ViewCompat.setOnApplyWindowInsetsListener(binding.root) { v, insets ->
            val systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars())
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom)
            insets
        }

        // 전달받은 값 받기
        val keyword = intent.getStringExtra("SEARCH_KEYWORD") ?: ""
        // API 호출 메서드 호출
        performApiCall(keyword)
    }

    private fun performApiCall(keyword: String) {

        var retrofitAPI = ApiClient.getInstance().create(
            BithumbApi::class.java
        )

        retrofitAPI.getCoinNowPrice(
            "KRW-${keyword}"
        ).enqueue(object : Callback<List<NowPriceResponse>> {
            override fun onResponse(
                call: Call<List<NowPriceResponse>>,
                response: Response<List<NowPriceResponse>>
            ) {
                if (response.isSuccessful) {
                    val dataList = response.body()

                    if (!dataList.isNullOrEmpty()) {
                        val data = dataList[0]
                        runOnUiThread {
                            binding.coinName.text = keyword
                            binding.openingPriceValue.text = data.opening_price.toString()
                            binding.highPriceValue.text = data.high_price.toString()
                            binding.lowPriceValue.text = data.low_price.toString()
                        }
                    } else {
                        Log.e("ccc", "응답이 null입니다.")
                    }
                } else {
                    Log.e("ccc", "API 호출 실패 - code: ${response.code()}")
                }
            }

            override fun onFailure(call: Call<List<NowPriceResponse>>, t: Throwable) {
                Log.e("API", "호출 실패: ${t.message}")
            }
        }
        )
    }
}