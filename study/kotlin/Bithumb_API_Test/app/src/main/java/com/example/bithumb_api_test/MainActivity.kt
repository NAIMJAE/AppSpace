package com.example.bithumb_api_test

import android.content.Intent
import android.os.Bundle
import android.widget.Toast
import androidx.activity.enableEdgeToEdge
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import com.example.bithumb_api_test.databinding.ActivityMainBinding

class MainActivity : AppCompatActivity() {

    // xml 파일의 view 요소들에 쉽게 접근하는 방법
    // build.gradle 에서 viewBinding을 활성화 시켜야함
    private lateinit var binding: ActivityMainBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        
        // binding 설정
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)
        
        ViewCompat.setOnApplyWindowInsetsListener(binding.root) { v, insets ->
            val systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars())
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom)
            insets
        }

        setClickListeners()
    }

    // 버튼 동작 감지
    private fun setClickListeners() {
        binding.searchBtn.setOnClickListener { handleSearchClick() }
    }

    // 검색 버튼
    private fun handleSearchClick() {
        val inputText = binding.inputSymbol.text.toString().trim()

        if (inputText.isEmpty()) {
            Toast.makeText(this, "값을 입력하세요.", Toast.LENGTH_SHORT).show()
        } else {
            val intent = Intent(this, ResultActivity::class.java).apply {
                putExtra("SEARCH_KEYWORD", inputText)
            }
            startActivity(intent)
        }
    }
}