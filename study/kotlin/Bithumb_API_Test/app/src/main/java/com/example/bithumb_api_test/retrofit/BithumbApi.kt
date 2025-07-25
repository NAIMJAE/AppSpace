package com.example.bithumb_api_test.retrofit

import retrofit2.Call
import retrofit2.http.GET
import retrofit2.http.Query

interface BithumbApi {
    @GET("v1/ticker")
    fun getCoinNowPrice(@Query("markets") symbol: String): Call<List<NowPriceResponse>>
}