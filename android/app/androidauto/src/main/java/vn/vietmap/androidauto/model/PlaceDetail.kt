package vn.vietmap.androidauto.model

import com.google.gson.annotations.SerializedName

data class PlaceDetail(
    val display: String,
    val name: String,
    @SerializedName("hs_num") val houseNumber: String,
    val street: String,
    val address: String,
    @SerializedName("city_id") val cityId: Int,
    val city: String,
    @SerializedName("district_id") val districtId: Int,
    val district: String,
    @SerializedName("ward_id") val wardId: Int,
    val ward: String,
    val lat: Double,
    val lng: Double
)
