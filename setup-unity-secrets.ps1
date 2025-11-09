# ?? CONFIGURAR UNITY SECRETS - AUTOMATIZADO

Write-Host "??????????????????????????????????????????????" -ForegroundColor Cyan
Write-Host "?  ?? CONFIGURAR UNITY SECRETS NO GITHUB  ?" -ForegroundColor Cyan
Write-Host "??????????????????????????????????????????????" -ForegroundColor Cyan
Write-Host ""

# Unity License XML (já fornecido)
$unityLicense = @'
<?xml version="1.0" encoding="UTF-8"?><root><TimeStamp Value="JASS5XOYz+tIIg=="/> <License id="Terms"> <MachineBindings> <Binding Key="1" Value="00355-61999-95039-AAOEM"/> <Binding Key="4" Value="NjRNMFg2NA=="/> <Binding Key="5" Value="08:b4:d2:95:5c:63"/> </MachineBindings> <MachineID Value="ADMVH5A1WFZW4IBc0l1no39U8y8="/> <SerialHash Value="3e5035247dd2edbb83d47fc0d9a4fda1870a5214"/> <Features> <Feature Value="33"/> <Feature Value="1"/> <Feature Value="12"/> <Feature Value="2"/> <Feature Value="24"/> <Feature Value="3"/> <Feature Value="36"/> <Feature Value="17"/> <Feature Value="19"/> <Feature Value="62"/> </Features> <DeveloperData Value="AQAAAEY0LTc2VTMtNk1TQi1ISjhRLUU3R1AtV1Y3TQ=="/> <SerialMasked Value="F4-76U3-6MSB-HJ8Q-E7GP-XXXX"/> <StartDate Value="2025-11-07T00:00:00"/> <UpdateDate Value="2025-11-08T16:53:15"/> <InitialActivationDate Value="2025-11-07T15:05:33"/> <LicenseVersion Value="6.x"/> <ClientProvidedVersion Value="2017.2.0"/> <AlwaysOnline Value="false"/> <Entitlements> <Entitlement Ns="unity_editor" Tag="UnityPersonal" Type="EDITOR" ValidTo="9999-12-31T00:00:00"/> <Entitlement Ns="unity_editor" Tag="DarkSkin" Type="EDITOR_FEATURE" ValidTo="9999-12-31T00:00:00"/> </Entitlements> </License><Signature xmlns="http://www.w3.org/2000/09/xmldsig#"><SignedInfo><CanonicalizationMethod Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315#WithComments"/><SignatureMethod Algorithm="http://www.w3.org/2000/09/xmldsig#rsa-sha1"/><Reference URI="#Terms"><Transforms><Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature"/></Transforms><DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1"/><DigestValue>3XNRiadHZzt9BxgKANZnie/SicA=</DigestValue></Reference></SignedInfo><SignatureValue>Bq8JhTesUt5aeeDo2ZbgRZu2UlHBwUxnRtH0SQc9lvWu5gCZdDjMYl18H0A3ni0NazyW57hz/8nd xQnL8t32H/IjWZDCCu6ZImGCxuC3sGNtH8ktf2PzoqTtn+GWuj549/lHwwVdOKTVf5GauwXnKM6F O+SB96eIsC7riXMsosH14JBSmMV1mw8y0z/a8VZKcHJ1mwxhLLTL/AJ399O8TGQZr4yk10JIIZ2B KRQaWe6wSW92OjWUnGUnMaU0QEbm63HuWqInkaseu130cNpv4Pezb5Jlh7f8JSP4RBVOYeTJtK+m PLssKcS9pU4UvLwZHxuGU+9cwz1yQQKV7lQzBQ==</SignatureValue></Signature></root>
'@

Write-Host "? Unity License encontrada!" -ForegroundColor Green
Write-Host ""
Write-Host "?? Informações da Licença:" -ForegroundColor Cyan
Write-Host "  Tipo: Unity Personal (Free)" -ForegroundColor White
Write-Host "  Serial: F4-76U3-6MSB-HJ8Q-E7GP-XXXX" -ForegroundColor White
Write-Host "  Validade: 9999-12-31 (vitalício)" -ForegroundColor White
Write-Host ""

# Pedir email e senha
Write-Host "?? Digite seu EMAIL da conta Unity:" -ForegroundColor Yellow
$unityEmail = Read-Host "Email"

Write-Host ""
Write-Host "?? Digite sua SENHA da conta Unity:" -ForegroundColor Yellow
$unityPasswordSecure = Read-Host "Senha" -AsSecureString
$unityPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($unityPasswordSecure))

Write-Host ""
Write-Host "???????????????????????????????????????????" -ForegroundColor Cyan
Write-Host ""

# Copiar Unity License para clipboard
$unityLicense | Set-Clipboard
Write-Host "? Unity License copiada para clipboard!" -ForegroundColor Green
Write-Host ""

Write-Host "?? INSTRUÇÕES:" -ForegroundColor Cyan
Write-Host ""
Write-Host "Vou abrir o GitHub Secrets 3 vezes." -ForegroundColor White
Write-Host "Adicione cada secret conforme instruções abaixo:" -ForegroundColor White
Write-Host ""

Write-Host "???????????????????????????????????????????" -ForegroundColor Yellow
Write-Host "SECRET 1/3: UNITY_LICENSE" -ForegroundColor Yellow
Write-Host "???????????????????????????????????????????" -ForegroundColor Yellow
Write-Host ""
Write-Host "Name: UNITY_LICENSE" -ForegroundColor White
Write-Host "Secret: Ctrl+V (já está na clipboard)" -ForegroundColor Green
Write-Host ""
$null = Read-Host "Pressione ENTER para abrir GitHub"

Start-Process "https://github.com/avilaops/barbara/settings/secrets/actions/new"
Write-Host ""
Write-Host "? Aguardando você adicionar o secret..." -ForegroundColor Gray
$null = Read-Host "Pressione ENTER quando terminar"

Write-Host ""
Write-Host "???????????????????????????????????????????" -ForegroundColor Yellow
Write-Host "SECRET 2/3: UNITY_EMAIL" -ForegroundColor Yellow
Write-Host "???????????????????????????????????????????" -ForegroundColor Yellow
Write-Host ""
Write-Host "Name: UNITY_EMAIL" -ForegroundColor White
Write-Host "Secret: $unityEmail" -ForegroundColor White
Write-Host ""

# Copiar email para clipboard
$unityEmail | Set-Clipboard
Write-Host "? Email copiado para clipboard!" -ForegroundColor Green
Write-Host ""
$null = Read-Host "Pressione ENTER para abrir GitHub"

Start-Process "https://github.com/avilaops/barbara/settings/secrets/actions/new"
Write-Host ""
Write-Host "? Aguardando você adicionar o secret..." -ForegroundColor Gray
$null = Read-Host "Pressione ENTER quando terminar"

Write-Host ""
Write-Host "???????????????????????????????????????????" -ForegroundColor Yellow
Write-Host "SECRET 3/3: UNITY_PASSWORD" -ForegroundColor Yellow
Write-Host "???????????????????????????????????????????" -ForegroundColor Yellow
Write-Host ""
Write-Host "Name: UNITY_PASSWORD" -ForegroundColor White
Write-Host "Secret: (sua senha - já copiada)" -ForegroundColor White
Write-Host ""

# Copiar senha para clipboard
$unityPassword | Set-Clipboard
Write-Host "? Senha copiada para clipboard!" -ForegroundColor Green
Write-Host ""
$null = Read-Host "Pressione ENTER para abrir GitHub"

Start-Process "https://github.com/avilaops/barbara/settings/secrets/actions/new"
Write-Host ""
Write-Host "? Aguardando você adicionar o secret..." -ForegroundColor Gray
$null = Read-Host "Pressione ENTER quando terminar"

Write-Host ""
Write-Host "???????????????????????????????????????????" -ForegroundColor Green
Write-Host ""
Write-Host "? TODOS OS SECRETS CONFIGURADOS!" -ForegroundColor Green
Write-Host ""
Write-Host "?? Verificar secrets:" -ForegroundColor Cyan
Start-Process "https://github.com/avilaops/barbara/settings/secrets/actions"
Write-Host ""
Write-Host "Você deve ver 5 secrets no total:" -ForegroundColor White
Write-Host "  ? AZURE_STATIC_WEB_APPS_API_TOKEN" -ForegroundColor Green
Write-Host "  ? AZURE_WEBAPP_PUBLISH_PROFILE" -ForegroundColor Green
Write-Host "  ? UNITY_LICENSE ? NOVO" -ForegroundColor Yellow
Write-Host "  ? UNITY_EMAIL ? NOVO" -ForegroundColor Yellow
Write-Host "  ? UNITY_PASSWORD ? NOVO" -ForegroundColor Yellow
Write-Host ""

Write-Host "???????????????????????????????????????????" -ForegroundColor Cyan
Write-Host ""
Write-Host "?? PRÓXIMO PASSO: TESTAR DEPLOY!" -ForegroundColor Cyan
Write-Host ""
Write-Host "Opção A - Manual (Recomendado):" -ForegroundColor Yellow
Write-Host "  1. GitHub ? Actions" -ForegroundColor White
Write-Host "  2. Deploy Completo - Bárbara E-commerce" -ForegroundColor White
Write-Host "  3. Run workflow ? main ? Run workflow" -ForegroundColor White
Write-Host "  4. Aguardar ~15 minutos" -ForegroundColor White
Write-Host ""
Write-Host "Opção B - Automático:" -ForegroundColor Yellow
Write-Host '  git commit --allow-empty -m "test: Deploy Unity WebGL"' -ForegroundColor White
Write-Host "  git push" -ForegroundColor White
Write-Host ""

$abrir = Read-Host "Deseja abrir GitHub Actions agora? (S/N)"
if ($abrir -eq "S" -or $abrir -eq "s") {
    Start-Process "https://github.com/avilaops/barbara/actions"
}

Write-Host ""
Write-Host "???????????????????????????????????????????" -ForegroundColor Green
Write-Host "    CONFIGURAÇÃO CONCLUÍDA!         " -ForegroundColor Green
Write-Host "???????????????????????????????????????????" -ForegroundColor Green
Write-Host ""
Write-Host "?? Após o deploy, acesse:" -ForegroundColor Cyan
Write-Host "   https://barbara.avila.inc" -ForegroundColor Green
Write-Host ""
