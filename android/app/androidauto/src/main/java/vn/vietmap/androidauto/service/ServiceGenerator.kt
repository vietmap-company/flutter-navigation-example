package vn.vietmap.androidauto.service

import com.google.gson.Gson
import okhttp3.Interceptor
import okhttp3.OkHttpClient
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import vn.vietmap.androidauto.helper.VietMapNavigationHelper
private const val apiKey = "apikey"
private const val contentType = "Content-Type"
private const val contentTypeValue = "application/json"


class ServiceGenerator {
    companion object{
        private val okHttpBuilder: OkHttpClient.Builder = OkHttpClient.Builder()
        private val retrofit: Retrofit


        private var headerInterceptor = Interceptor { chain ->
            val original = chain.request()

            val request = original.newBuilder()
                .header(contentType, contentTypeValue)
                .method(original.method, original.body)
                .build()

            chain.proceed(request)
        }

        private val accessKeyInterceptor = Interceptor { chain ->
            val originalRequest = chain.request()
            val urlWithAccessKey = originalRequest.url.newBuilder()
                .addQueryParameter(apiKey, VietMapNavigationHelper.apiKey)
                .build()

            val newRequest = originalRequest.newBuilder()
                .url(urlWithAccessKey)
                .build()

            chain.proceed(newRequest)
        }


        init {
            okHttpBuilder.addInterceptor(headerInterceptor)
            okHttpBuilder.addInterceptor(accessKeyInterceptor)
            val client: OkHttpClient = okHttpBuilder.build()
            retrofit = Retrofit.Builder()
                .baseUrl("https://maps.vietmap.vn")
                .client(client).addConverterFactory(GsonConverterFactory.create(Gson()))
                .build()
        }

        fun <S> createService(serviceClass: Class<S>): S {
            return retrofit.create(serviceClass)
        }
    }
}