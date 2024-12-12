package vn.vietmap.androidauto.model

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity
data class PlaceItem(
    @PrimaryKey val ref_id: String,
    val address: String,
    val name: String
)

