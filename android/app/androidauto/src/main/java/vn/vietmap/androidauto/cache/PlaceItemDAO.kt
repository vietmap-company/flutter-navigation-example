package vn.vietmap.androidauto.cache

import androidx.room.Dao
import androidx.room.Delete
import androidx.room.Insert
import androidx.room.Query
import vn.vietmap.androidauto.model.PlaceItem

@Dao
interface PlaceItemDAO {
    @Query("SELECT * FROM PlaceItem")
    fun getAll(): List<PlaceItem>

    @Insert
    fun insertAll(vararg placeItems: PlaceItem)

    @Delete
    fun delete(placeItem: PlaceItem)
}