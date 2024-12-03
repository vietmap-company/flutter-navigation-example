package vn.vietmap.androidauto.service

import retrofit2.Response
import retrofit2.http.GET
import retrofit2.http.Query
import vn.vietmap.androidauto.model.PlaceDetail
import vn.vietmap.androidauto.model.PlaceItem

interface SearchScreenService {
    @GET("/api/autocomplete/v3")
    suspend fun autocomplete(@Query("text") text: String, @Query("focus") focus: String?): Response<List<PlaceItem>>

    @GET("/api/place/v3")
    suspend fun getPlaceDetail(@Query("refid") refId: String): Response<PlaceDetail>
}