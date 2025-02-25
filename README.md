به کمک keytool که از ابزار خود Jdk هست یک کلید میسازید.
keytool -genkeypair -alias mykey2 -keyalg RSA -keysize 2048 -keystore D:\Learning\TestSignProject\src\main\resources\mykeystore2.jks -storepass adminadmin2 -validity 365
alias -> نام کلید
Keyalg -> الگوریتم ساخت کلید
Keysize -> طول کلید
Keystore -> مسیر ذخیره سازی کلید
Storepass -> پسورد store
Validity -> مدت اعتبار کلید
نکته : پس از وارد کردن این دستور از شما پسوردی میخواهد که پسورد دسترسی به کلید شماست(keypass)، ان را به خاطر بسپارید.






پلاگین زیر را به پروژه خود اضافه کنید.
<plugin>
	<groupId>org.apache.maven.plugins</groupId>
	<artifactId>maven-jarsigner-plugin</artifactId>
	<version>3.0.0</version>
	<executions>
		<execution>
			<id>sign</id>
			<phase>package</phase>
			<goals>
				<goal>sign</goal>
			</goals>
			<configuration>
				<keystore>${project.basedir}/src/main/resources/mykeystore2.jks</keystore>
				<storepass>adminadmin2</storepass>
				<keypass>Ariya@13792</keypass>
				<alias>mykey2</alias>
			</configuration>
		</execution>
	</executions>
</plugin>
Keystore -> مسیر کلید شما
Storepass -> پسورد store
Keypass -> رمز دسترسی به کلید (مقداری که قرار بود به خاطر سپرده شود).
Alias -> نام کلید

