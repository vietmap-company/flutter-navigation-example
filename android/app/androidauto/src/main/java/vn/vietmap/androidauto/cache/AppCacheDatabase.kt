package vn.vietmap.androidauto.cache

import androidx.room.Database
import androidx.room.RoomDatabase
import vn.vietmap.androidauto.model.PlaceItem

@Database(entities = [PlaceItem::class], version = 1)
abstract class AppCacheDatabase : RoomDatabase() {
    abstract fun placeItemDAO(): PlaceItemDAO
}